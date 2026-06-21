import { jest } from "@jest/globals";

// --- Mocks ---

jest.unstable_mockModule("../src/config/db.js", () => ({
  prisma: {
    apartment: {
      count: jest.fn(),
    },
    due: {
      groupBy: jest.fn(),
    },
    expense: {
      aggregate: jest.fn(),
    },
    notification: {
      count: jest.fn(),
    },
    ticket: {
      count: jest.fn(),
    },
    dekont: {
      count: jest.fn(),
    },
  },
}));

jest.unstable_mockModule("../src/utils/access.js", () => ({
  assertManagerOwnsBuilding: jest.fn(),
}));

jest.unstable_mockModule("../src/utils/asyncHandler.js", () => ({
  asyncHandler: (fn) => fn,
}));

const { prisma } = await import("../src/config/db.js");
const { assertManagerOwnsBuilding } = await import("../src/utils/access.js");
const { getDashboardSummary } = await import("../src/controllers/dashboardController.js");

// --- Helpers ---

function mockReq(buildingId, managerId) {
  return { params: { id: buildingId }, user: { id: managerId } };
}

function mockRes() {
  const res = {
    _status: 200,
    _body: null,
    status(code) { res._status = code; return res; },
    json(body) { res._body = body; return res; },
  };
  return res;
}

// --- Tests ---

describe("DashboardController — getDashboardSummary", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    assertManagerOwnsBuilding.mockResolvedValue({ id: "b1", managerId: "m1" });
    prisma.apartment.count.mockResolvedValue(8);
    prisma.due.groupBy.mockResolvedValue([
      { status: "PAID", _count: 5, _sum: { amount: 5000 } },
      { status: "PENDING", _count: 3, _sum: { amount: 3000 } },
    ]);
    prisma.expense.aggregate.mockResolvedValue({
      _sum: { amount: 2500 },
      _count: 4,
    });
    prisma.notification.count.mockResolvedValue(2);
    prisma.ticket.count.mockResolvedValue(1);
    prisma.dekont.count.mockResolvedValue(3);
  });

  test("returns aggregated dashboard data", async () => {
    // occupied apartments = second call
    prisma.apartment.count
      .mockResolvedValueOnce(8) // total
      .mockResolvedValueOnce(6); // occupied

    const req = mockReq("b1", "m1");
    const res = mockRes();

    await getDashboardSummary(req, res);

    expect(res._status).toBe(200);
    expect(res._body.success).toBe(true);

    const data = res._body.data;
    expect(data.apartments.total).toBe(8);
    expect(data.apartments.occupied).toBe(6);
    expect(data.dues.PAID.count).toBe(5);
    expect(data.dues.PAID.totalAmount).toBe(5000);
    expect(data.dues.PENDING.count).toBe(3);
    expect(data.expenses.total).toBe(2500);
    expect(data.expenses.count).toBe(4);
    expect(data.unreadNotifications).toBe(2);
    expect(data.openTickets).toBe(1);
    expect(data.pendingDekonts).toBe(3);
    expect(data.period).toHaveProperty("month");
    expect(data.period).toHaveProperty("year");
  });

  test("calls assertManagerOwnsBuilding for auth check", async () => {
    const req = mockReq("b1", "m1");
    const res = mockRes();

    await getDashboardSummary(req, res);

    expect(assertManagerOwnsBuilding).toHaveBeenCalledWith("b1", "m1");
  });

  test("handles empty dues (no groups)", async () => {
    prisma.apartment.count.mockResolvedValue(4).mockResolvedValue(4);
    prisma.due.groupBy.mockResolvedValue([]);

    const req = mockReq("b1", "m1");
    const res = mockRes();

    await getDashboardSummary(req, res);

    expect(res._body.data.dues).toEqual({});
  });

  test("handles null expense sum gracefully", async () => {
    prisma.apartment.count.mockResolvedValue(4).mockResolvedValue(4);
    prisma.expense.aggregate.mockResolvedValue({ _sum: { amount: null }, _count: 0 });

    const req = mockReq("b1", "m1");
    const res = mockRes();

    await getDashboardSummary(req, res);

    expect(res._body.data.expenses.total).toBe(0);
    expect(res._body.data.expenses.count).toBe(0);
  });
});
