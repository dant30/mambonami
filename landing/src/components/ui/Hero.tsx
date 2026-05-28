interface HeroProps {
  title: string
  subtitle: string
  ctaText?: string
  ctaLink?: string
  backgroundImage?: string
}

const Hero = ({ title, subtitle, ctaText, ctaLink, backgroundImage }: HeroProps) => {
  return (
    <section className={`bg-primary text-white py-20 ${backgroundImage ? 'bg-cover bg-center' : ''}`} style={backgroundImage ? { backgroundImage: `url(${backgroundImage})` } : {}}>
      <div className="container-custom text-center">
        <h1 className="text-4xl md:text-6xl font-bold mb-4">{title}</h1>
        <p className="text-xl md:text-2xl mb-8 opacity-90">{subtitle}</p>
        {ctaText && ctaLink && (
          <a href={ctaLink} className="bg-white text-primary px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition">
            {ctaText}
          </a>
        )}
      </div>
    </section>
  )
}
export default Hero