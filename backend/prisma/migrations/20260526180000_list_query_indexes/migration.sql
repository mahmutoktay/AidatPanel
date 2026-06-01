-- CreateIndex
CREATE INDEX "Due_apartmentId_year_month_idx" ON "Due"("apartmentId", "year", "month");

-- CreateIndex
CREATE INDEX "Expense_buildingId_date_idx" ON "Expense"("buildingId", "date");
