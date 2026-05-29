import { useState } from 'react'

const faqs = [
  { q: "How do I register as a farmer?", a: "Download the app, select 'Farmer' role, verify phone, submit cooperative endorsement (or waiver), and start listing products." },
  { q: "How are payments secured?", a: "Payments go into M-Pesa PayBill escrow and are released only after delivery confirmation." },
  { q: "What if I receive damaged goods?", a: "You have 2 hours to raise a dispute with photo evidence. We will review and issue a partial refund if valid." },
]

export default function FAQ() {
  const [open, setOpen] = useState<number | null>(null)
  return (
    <div className="container-custom py-16">
      <h1 className="text-4xl font-bold mb-8 text-center">Frequently Asked Questions</h1>
      <div className="max-w-3xl mx-auto space-y-4">
        {faqs.map((faq, idx) => (
          <div key={idx} className="border rounded-lg">
            <button className="w-full text-left p-4 font-semibold flex justify-between items-center" onClick={() => setOpen(open === idx ? null : idx)}>
              {faq.q}
              <span>{open === idx ? 'âˆ’' : '+'}</span>
            </button>
            {open === idx && <div className="p-4 pt-0 text-gray-600">{faq.a}</div>}
          </div>
        ))}
      </div>
    </div>
  )
}