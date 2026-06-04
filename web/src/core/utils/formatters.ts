export const formatCurrency = (amount: number) => `KES ${amount.toLocaleString()}`;
export const formatDate = (date: string) => new Date(date).toLocaleDateString();
