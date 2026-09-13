const soundSources = {
  notification: '/sounds/alert.mp3',
  message: '/sounds/success.mp3',
} as const

type SoundName = keyof typeof soundSources

let audioContext: AudioContext | null = null
let unlockInstalled = false
let unlockCleanup: (() => void) | null = null

function getAudioContext(): AudioContext | null {
  if (typeof window === 'undefined') return null

  try {
    audioContext ??= new AudioContext()
    return audioContext
  } catch {
    return null
  }
}

async function unlockAudio(): Promise<void> {
  const context = getAudioContext()
  if (!context || context.state === 'running') return

  try {
    await context.resume()
  } catch {
    // The browser may require another user gesture before allowing audio.
  }
}

export function installNotificationSoundUnlock(): () => void {
  if (typeof window === 'undefined') return () => undefined
  if (unlockInstalled && unlockCleanup) return unlockCleanup

  unlockInstalled = true
  const events = ['pointerdown', 'keydown', 'touchstart'] as const
  events.forEach((event) => window.addEventListener(event, unlockAudio, { passive: true }))

  unlockCleanup = () => {
    events.forEach((event) => window.removeEventListener(event, unlockAudio))
    unlockInstalled = false
    unlockCleanup = null
  }
  return unlockCleanup
}

export function playNotificationSound(name: SoundName): void {
  if (typeof window === 'undefined') return

  const audio = new Audio(soundSources[name])
  audio.volume = 0.65
  void audio.play().catch(() => undefined)
}
