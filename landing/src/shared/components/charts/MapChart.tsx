import React, { useState } from 'react'
import { MapPin, Users, Building2, TrendingUp } from 'lucide-react'

export interface RegionDataPoint {
  id: string
  name: string
  workersCount: number
  employersCount: number
  jobsCount: number
  growthRate?: string
  coordinates?: { x: number; y: number } // percent positions on Kenya map container
}

export interface MapChartProps {
  regions?: RegionDataPoint[]
  title?: string
  subtitle?: string
  onSelectRegion?: (region: RegionDataPoint) => void
  className?: string
}

const DEFAULT_KENYA_REGIONS: RegionDataPoint[] = [
  {
    id: 'nairobi',
    name: 'Nairobi Region',
    workersCount: 840,
    employersCount: 165,
    jobsCount: 92,
    growthRate: '+24%',
    coordinates: { x: 55, y: 62 },
  },
  {
    id: 'mombasa',
    name: 'Mombasa & Coastal',
    workersCount: 390,
    employersCount: 78,
    jobsCount: 45,
    growthRate: '+18%',
    coordinates: { x: 74, y: 82 },
  },
  {
    id: 'nakuru',
    name: 'Nakuru & Central Rift',
    workersCount: 280,
    employersCount: 52,
    jobsCount: 31,
    growthRate: '+15%',
    coordinates: { x: 42, y: 54 },
  },
  {
    id: 'kisumu',
    name: 'Kisumu & Western',
    workersCount: 220,
    employersCount: 40,
    jobsCount: 24,
    growthRate: '+12%',
    coordinates: { x: 30, y: 58 },
  },
  {
    id: 'eldoret',
    name: 'Eldoret & North Rift',
    workersCount: 160,
    employersCount: 28,
    jobsCount: 19,
    growthRate: '+14%',
    coordinates: { x: 36, y: 46 },
  },
  {
    id: 'mt-kenya',
    name: 'Mount Kenya (Nyeri/Embu)',
    workersCount: 190,
    employersCount: 34,
    jobsCount: 22,
    growthRate: '+9%',
    coordinates: { x: 58, y: 52 },
  },
]

export const MapChart: React.FC<MapChartProps> = ({
  regions = DEFAULT_KENYA_REGIONS,
  title = 'Kenya Regional Coverage',
  subtitle = 'Verified workers, employers, and shift postings by county hub',
  onSelectRegion,
  className = '',
}) => {
  const [activeRegion, setActiveRegion] = useState<RegionDataPoint>(regions[0])

  const totalWorkers = regions.reduce((acc, curr) => acc + curr.workersCount, 0)
  const totalJobs = regions.reduce((acc, curr) => acc + curr.jobsCount, 0)

  const handleSelect = (reg: RegionDataPoint) => {
    setActiveRegion(reg)
    if (onSelectRegion) onSelectRegion(reg)
  }

  return (
    <div className={`rounded-2xl border border-slate-200 bg-white p-5 shadow-sm ${className}`}>
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2 mb-6">
        <div>
          <h3 className="text-base font-black text-slate-900">{title}</h3>
          <p className="text-xs text-slate-500">{subtitle}</p>
        </div>
        <div className="flex items-center gap-2">
          <span className="inline-flex items-center gap-1.5 rounded-lg bg-orange-50 px-2.5 py-1 text-xs font-bold text-[#FF6B00]">
            <MapPin className="h-3.5 w-3.5" />
            {regions.length} Active Hubs
          </span>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        {/* Interactive Map Visual */}
        <div className="lg:col-span-6 relative aspect-[4/3] rounded-2xl bg-gradient-to-br from-[#0A2540] to-[#123E6B] p-4 text-white overflow-hidden shadow-inner flex flex-col justify-between">
          <div className="absolute inset-0 opacity-10 bg-[radial-gradient(#fff_1px,transparent_1px)] [background-size:16px_16px]" />
          
          <div className="relative z-10 flex items-center justify-between text-xs text-slate-300">
            <span className="font-bold tracking-wider uppercase text-[10px] text-[#FF6B00]">KENYA MAP VIEW</span>
            <span>Click a hub to view details</span>
          </div>

          {/* Map Hotspot Nodes */}
          <div className="relative flex-1 w-full my-2">
            {regions.map((reg) => {
              const coords = reg.coordinates || { x: 50, y: 50 }
              const isSelected = activeRegion.id === reg.id

              return (
                <button
                  key={reg.id}
                  type="button"
                  onClick={() => handleSelect(reg)}
                  style={{ left: `${coords.x}%`, top: `${coords.y}%` }}
                  className={`absolute -translate-x-1/2 -translate-y-1/2 group flex flex-col items-center transition-all duration-300 ${
                    isSelected ? 'scale-125 z-20' : 'hover:scale-110 z-10'
                  }`}
                >
                  <span className="relative flex h-5 w-5">
                    {isSelected && (
                      <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#FF6B00] opacity-75" />
                    )}
                    <span
                      className={`relative inline-flex rounded-full h-5 w-5 items-center justify-center text-[9px] font-black shadow-md ${
                        isSelected
                          ? 'bg-[#FF6B00] text-white border-2 border-white'
                          : 'bg-white text-[#0A2540] hover:bg-orange-100'
                      }`}
                    >
                      {reg.jobsCount}
                    </span>
                  </span>
                  <span
                    className={`mt-1 whitespace-nowrap px-1.5 py-0.5 rounded text-[9px] font-bold ${
                      isSelected
                        ? 'bg-[#FF6B00] text-white shadow-md'
                        : 'bg-[#0A2540]/80 text-slate-200 group-hover:bg-[#0A2540]'
                    }`}
                  >
                    {reg.name.split(' ')[0]}
                  </span>
                </button>
              )
            })}
          </div>

          <div className="relative z-10 flex items-center justify-between border-t border-white/10 pt-2 text-xs text-slate-300">
            <div>Total Verified: <strong className="text-white">{totalWorkers.toLocaleString()}</strong></div>
            <div>Live Shifts: <strong className="text-[#FF6B00]">{totalJobs}</strong></div>
          </div>
        </div>

        {/* Region List & Details */}
        <div className="lg:col-span-6 space-y-3">
          {/* Active Region Highlight Card */}
          <div className="p-4 rounded-xl border border-orange-200 bg-orange-50/50">
            <div className="flex items-center justify-between">
              <div>
                <span className="text-[10px] font-bold uppercase tracking-wider text-orange-700">SELECTED HUB</span>
                <h4 className="text-base font-black text-slate-900">{activeRegion.name}</h4>
              </div>
              {activeRegion.growthRate && (
                <span className="inline-flex items-center gap-1 rounded-full bg-emerald-100 px-2.5 py-0.5 text-xs font-bold text-emerald-700">
                  <TrendingUp className="h-3 w-3" />
                  {activeRegion.growthRate}
                </span>
              )}
            </div>

            <div className="grid grid-cols-3 gap-2 mt-3 pt-3 border-t border-orange-200/60 text-center">
              <div className="bg-white rounded-lg p-2 border border-orange-100 shadow-sm">
                <Users className="h-3.5 w-3.5 mx-auto text-[#0A2540] mb-1" />
                <div className="text-sm font-black text-slate-900">{activeRegion.workersCount}</div>
                <div className="text-[10px] text-slate-500">Workers</div>
              </div>
              <div className="bg-white rounded-lg p-2 border border-orange-100 shadow-sm">
                <Building2 className="h-3.5 w-3.5 mx-auto text-[#0A2540] mb-1" />
                <div className="text-sm font-black text-slate-900">{activeRegion.employersCount}</div>
                <div className="text-[10px] text-slate-500">Venues</div>
              </div>
              <div className="bg-white rounded-lg p-2 border border-orange-100 shadow-sm">
                <MapPin className="h-3.5 w-3.5 mx-auto text-[#FF6B00] mb-1" />
                <div className="text-sm font-black text-[#FF6B00]">{activeRegion.jobsCount}</div>
                <div className="text-[10px] text-slate-500">Live Shifts</div>
              </div>
            </div>
          </div>

          {/* Quick List */}
          <div className="space-y-1.5 max-h-[160px] overflow-y-auto pr-1">
            {regions.map((reg) => (
              <button
                key={reg.id}
                type="button"
                onClick={() => handleSelect(reg)}
                className={`w-full flex items-center justify-between p-2.5 rounded-xl border text-left text-xs transition-all ${
                  activeRegion.id === reg.id
                    ? 'border-[#FF6B00] bg-white shadow-sm font-bold text-slate-900'
                    : 'border-slate-100 bg-slate-50 hover:bg-white text-slate-600'
                }`}
              >
                <div className="flex items-center gap-2">
                  <span
                    className={`h-2 w-2 rounded-full ${
                      activeRegion.id === reg.id ? 'bg-[#FF6B00]' : 'bg-slate-300'
                    }`}
                  />
                  <span>{reg.name}</span>
                </div>
                <div className="flex items-center gap-3">
                  <span className="text-slate-400 font-normal">{reg.workersCount} workers</span>
                  <span className="font-bold text-slate-800">{reg.jobsCount} shifts</span>
                </div>
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
