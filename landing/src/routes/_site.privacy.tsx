import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/_site/privacy")({
  head: () => ({
    meta: [
      { title: "Privacy Policy — MAMBONAMI" },
      { name: "description", content: "How MAMBONAMI collects, uses, and protects your data." },
      { property: "og:title", content: "Privacy Policy — MAMBONAMI" },
      { property: "og:description", content: "How MAMBONAMI collects, uses, and protects your data." },
      { property: "og:url", content: "https://mambo-garden-hub.lovable.app/privacy" },
    ],
    links: [{ rel: "canonical", href: "https://mambo-garden-hub.lovable.app/privacy" }],
  }),
  component: PrivacyPage,
});

function PrivacyPage() {
  return (
    <section className="container mx-auto px-4 sm:px-6 lg:px-8 py-20 max-w-3xl">
      <header className="mb-10">
        <h1 className="font-display text-5xl font-bold mb-3">Privacy Policy</h1>
        <p className="text-muted-foreground">Last updated: May 2026</p>
      </header>

      <div className="space-y-8 text-foreground/90 leading-relaxed">
        <p>
          MAMBONAMI ("we", "our", or "us") is committed to protecting your privacy. This
          policy explains how we collect, use, disclose, and safeguard your information when
          you use our marketplace and logistics platform.
        </p>

        <section>
          <h2 className="font-display text-2xl font-semibold mb-3">1. Information We Collect</h2>
          <p className="mb-3">We collect information that you provide directly to us:</p>
          <ul className="list-disc pl-6 space-y-2">
            <li><strong>Account Information:</strong> Name, phone number, email address, role (farmer, buyer, retailer, transport provider)</li>
            <li><strong>Farm/Supplier Information:</strong> GPS location of farm/pickup point, product categories, harvest dates</li>
            <li><strong>Delivery Information:</strong> Delivery address, GPS location, contact details for delivery</li>
            <li><strong>Payment Information:</strong> M-Pesa phone number, transaction codes, payment amounts</li>
            <li><strong>Vehicle &amp; Licensing Information:</strong> (for transport providers) vehicle type, license plate, driver's license</li>
            <li><strong>Photos &amp; Evidence:</strong> Product images, proof of delivery photos, dispute evidence</li>
            <li><strong>Device &amp; Usage Data:</strong> Device type, IP address, app usage, geolocation (with permission)</li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-2xl font-semibold mb-3">2. How We Use Your Information</h2>
          <ul className="list-disc pl-6 space-y-2">
            <li><strong>Facilitate transactions</strong> – connect buyers, farmers, and transport providers</li>
            <li><strong>Process payments</strong> – collect and release escrow payments via M-Pesa</li>
            <li><strong>Coordinate logistics</strong> – match transport providers with orders and track deliveries</li>
            <li><strong>Verify identity</strong> – prevent fraud and ensure safety</li>
            <li><strong>Improve our services</strong> – analyse usage, resolve disputes, and provide support</li>
            <li><strong>Communicate with you</strong> – send order updates, OTPs, and notifications</li>
            <li><strong>Comply with legal obligations</strong> – tax, regulatory, and security requirements</li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-2xl font-semibold mb-3">3. How We Share Your Information</h2>
          <p className="mb-3">We share your information only when necessary:</p>
          <ul className="list-disc pl-6 space-y-2">
            <li><strong>Between users</strong> – farmers see buyer's delivery location; transport providers see pickup/delivery details; buyers see farmer's product and pickup location</li>
            <li><strong>With payment processors</strong> – Safaricom (M-Pesa) for payment collection and disbursement</li>
            <li><strong>With messaging services</strong> – Twilio/WhatsApp for order notifications and OTPs</li>
            <li><strong>With cloud hosting</strong> – AWS/DigitalOcean for data storage</li>
            <li><strong>When required by law</strong> – to comply with legal processes or regulatory requirements</li>
          </ul>
          <p className="mt-3 font-medium">We do not sell your personal data to third parties.</p>
        </section>

        <section>
          <h2 className="font-display text-2xl font-semibold mb-3">4. Data Storage &amp; Security</h2>
          <ul className="list-disc pl-6 space-y-2">
            <li>Data is stored on secure servers in Kenya / cloud regions.</li>
            <li>All data transmitted between your device and our servers is encrypted (HTTPS/TLS).</li>
            <li>Passwords are hashed and never stored in plain text.</li>
            <li>Access to personal data is restricted to authorised personnel only.</li>
            <li>We retain your data only as long as necessary to provide our services or as required by law.</li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-2xl font-semibold mb-3">5. Your Rights</h2>
          <p className="mb-3">You have the right to:</p>
          <ul className="list-disc pl-6 space-y-2">
            <li><strong>Access</strong> – request a copy of the personal data we hold about you</li>
            <li><strong>Correct</strong> – update inaccurate or incomplete information</li>
            <li><strong>Delete</strong> – request deletion of your data (subject to legal obligations)</li>
            <li><strong>Withdraw consent</strong> – opt out of certain data processing (e.g., location tracking)</li>
            <li><strong>Data portability</strong> – receive your data in a structured, machine-readable format</li>
          </ul>
          <p className="mt-3">
            To exercise these rights, contact us at{" "}
            <a className="text-primary underline" href="mailto:privacy@mambonami.com">privacy@mambonami.com</a>.
          </p>
        </section>

        <section>
          <h2 className="font-display text-2xl font-semibold mb-3">6. Children's Privacy</h2>
          <p>
            Our services are not directed to individuals under 18. We do not knowingly collect
            personal information from children. If you believe we have inadvertently collected
            such data, please contact us.
          </p>
        </section>

        <section>
          <h2 className="font-display text-2xl font-semibold mb-3">7. Third-Party Services</h2>
          <p className="mb-3">We use the following third-party services that may process your data:</p>
          <ul className="list-disc pl-6 space-y-2">
            <li><strong>Safaricom M-Pesa</strong> – payments</li>
            <li><strong>Twilio</strong> – WhatsApp/SMS notifications</li>
            <li><strong>SendGrid</strong> – email notifications</li>
            <li><strong>Firebase</strong> – push notifications</li>
            <li><strong>AWS / DigitalOcean</strong> – cloud hosting</li>
            <li><strong>Google Analytics</strong> – usage analytics (optional, with anonymisation)</li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-2xl font-semibold mb-3">8. Cookies &amp; Tracking</h2>
          <p>
            We use essential cookies to maintain session state and remember preferences. We do
            not use tracking cookies for advertising. You can manage cookie preferences in
            your browser settings.
          </p>
        </section>

        <section>
          <h2 className="font-display text-2xl font-semibold mb-3">9. Changes to This Policy</h2>
          <p>
            We may update this privacy policy from time to time. Changes will be posted on this
            page with an updated "Last updated" date. Continued use of the platform after
            changes constitutes acceptance of the new policy.
          </p>
        </section>

        <section>
          <h2 className="font-display text-2xl font-semibold mb-3">10. Contact Us</h2>
          <p className="mb-3">If you have questions about this privacy policy or your data:</p>
          <ul className="space-y-2">
            <li>📧 Email: <a className="text-primary underline" href="mailto:privacy@mambonami.com">privacy@mambonami.com</a></li>
            <li>📱 Phone: <a className="text-primary underline" href="tel:+254724167076">+254 724 167 076</a></li>
            <li>📍 Address: MAMBONAMI, Nairobi, Kenya</li>
          </ul>
        </section>

        <p className="pt-6 border-t border-border text-muted-foreground italic">
          MAMBONAMI – Fresh Produce Marketplace &amp; Logistics
        </p>
      </div>
    </section>
  );
}
