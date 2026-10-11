import { Button } from '../../../../../shared/components/ui/Button'

export function MetricsRecomputeButton({ busy, onRecompute }: { busy: boolean; onRecompute: () => void }) {
	return <Button size="sm" disabled={busy} onClick={onRecompute}>{busy ? 'Starting' : 'Recompute today'}</Button>
}