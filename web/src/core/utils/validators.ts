export const validatePhone = (phone: string) => /^07[0-9]{8}$/.test(phone);
export const validateEmail = (email: string) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
