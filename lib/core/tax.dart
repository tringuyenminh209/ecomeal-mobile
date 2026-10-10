// Thuế tiêu dùng (消費税). Mọi giá trong app là giá đã gồm thuế (総額表示); đồ ăn mang về chịu thuế suất giảm 8%.
// Cùng công thức với cột sinh orders.tax_amount (migration 0046): floor(giá × rate ÷ (100 + rate)) — đổi một bên thì
// phải đổi bên kia. App chỉ tự tính khi chưa có đơn (SCR-M05); đơn đã tạo thì dùng tax_amount của server.
const reducedTaxRate = 8;

int includedTax(int priceWithTax, {int rate = reducedTaxRate}) => priceWithTax * rate ~/ (100 + rate);
