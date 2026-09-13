import { ArrowRight, Leaf } from 'lucide-react'
import { Link } from 'react-router-dom'
import { useEffect, useState } from 'react'

import { Carousel, CarouselContent, CarouselItem, CarouselNext, CarouselPrevious } from '../../../shared/components/ui'
import type { CarouselApi } from '../../../shared/components/ui/Carousel'
import { MarketplaceSearch } from './MarketplaceSearch'

const slides = [
	{ image: '/assets/images/hero-farm.jpg', alt: 'Fresh vegetables growing on a Kenyan farm' },
	{ image: '/assets/images/gallery-2.jpg', alt: 'Fresh produce ready for market' },
	{ image: '/assets/images/gallery-3.jpg', alt: 'Farmers and fresh harvests' },
]

export function HeroSection() {
	const [api, setApi] = useState<CarouselApi | null>(null)
	useEffect(() => {
		if (!api) return
		const timer = window.setInterval(() => api.scrollNext(), 5000)
		return () => window.clearInterval(timer)
	}, [api])

	return <section className="relative overflow-hidden border-b border-border"><Carousel opts={{ loop: true }} setApi={setApi} className="w-full"><CarouselContent className="-ml-0">{slides.map((slide) => <CarouselItem key={slide.image} className="pl-0"><div className="relative min-h-[25rem] sm:min-h-[30rem] lg:min-h-[34rem]"><img src={slide.image} alt={slide.alt} className="absolute inset-0 h-full w-full object-cover transition-transform duration-1000 ease-out" /><div className="absolute inset-0 bg-primary-dark/65" /></div></CarouselItem>)}</CarouselContent><CarouselPrevious aria-label="Previous homepage image" className="left-3 top-1/2 z-20 border-white/30 bg-primary-foreground/15 text-primary-foreground hover:bg-primary-foreground/25 sm:left-6" /><CarouselNext aria-label="Next homepage image" className="right-3 top-1/2 z-20 border-white/30 bg-primary-foreground/15 text-primary-foreground hover:bg-primary-foreground/25 sm:right-6" /><div className="pointer-events-none absolute inset-0 z-10 flex items-center justify-center px-4 py-8 sm:px-6 lg:px-8"><div className="pointer-events-auto w-full max-w-3xl text-center text-primary-foreground animate-fade-in-up"><div className="mx-auto w-full max-w-2xl"><MarketplaceSearch /></div><p className="mt-5 flex items-center justify-center gap-2 text-xs font-bold uppercase tracking-[0.2em] text-secondary"><Leaf className="h-4 w-4" />Farm to table, made closer</p><h1 className="mt-3 text-4xl font-semibold leading-[0.98] sm:text-6xl">Fresh produce. Trusted suppliers.</h1><p className="mx-auto mt-4 max-w-xl text-sm leading-6 text-primary-foreground/80 sm:text-base">Discover Kenyan produce and have it delivered to you.</p><div className="mt-5 flex flex-wrap justify-center gap-3"><Link to="/products" className="inline-flex items-center gap-2 rounded-full bg-secondary px-5 py-3 text-sm font-bold text-secondary-foreground transition duration-200 hover:scale-[1.03] hover:shadow-glow">Browse products <ArrowRight className="h-4 w-4" /></Link><Link to="/how-it-works" className="inline-flex items-center rounded-full border border-primary-foreground/35 bg-primary-foreground/10 px-5 py-3 text-sm font-bold text-primary-foreground transition duration-200 hover:bg-primary-foreground/20">How it works</Link></div></div></div></Carousel></section>
}
