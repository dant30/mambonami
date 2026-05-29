export default function HowItWorks() {
  return (
    <div className="container-custom py-16">
      <h1 className="text-4xl font-bold mb-6">How It Works</h1>
      <ol className="list-decimal pl-6 space-y-4 text-gray-600">
        <li>Farmers list their products with harvest date and GPS location.</li>
        <li>Buyers browse, add to cart, and pay via M-Pesa PayBill.</li>
        <li>Funds are held in escrow until delivery.</li>
        <li>Transporters accept the job, pick up from farm, and deliver.</li>
        <li>Buyer confirms delivery with OTP, funds released to farmer & transporter.</li>
      </ol>
    </div>
  )
}