/** API yanıtlarında kullanıcı için güvenli alanlar (`passwordHash`, `refreshTokenVersion` yok). */
export const userPublicSelect = {
  id: true,
  email: true,
  name: true,
  role: true,
  phone: true,
  language: true,
  apartmentId: true,
  createdAt: true,
  updatedAt: true,
};

export function toPublicUser(user) {
  if (!user) return null;
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    role: user.role,
    phone: user.phone,
    language: user.language,
    apartmentId: user.apartmentId,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
  };
}
