export interface CameraOptions {
	facingMode?: 'user' | 'environment'
	width?: number
	height?: number
}

export async function requestCameraStream(options: CameraOptions = {}): Promise<MediaStream> {
	if (typeof navigator === 'undefined' || !navigator.mediaDevices?.getUserMedia) {
		throw new Error('Camera access is not supported in this browser.')
	}

	return navigator.mediaDevices.getUserMedia({
		video: {
			facingMode: options.facingMode ?? 'environment',
			...(options.width ? { width: { ideal: options.width } } : {}),
			...(options.height ? { height: { ideal: options.height } } : {}),
		},
		audio: false,
	})
}

export function stopCameraStream(stream: MediaStream | null | undefined): void {
	stream?.getTracks().forEach((track) => track.stop())
}

export function captureVideoFrame(video: HTMLVideoElement, type = 'image/jpeg', quality = 0.88): Blob {
	if (!video.videoWidth || !video.videoHeight) throw new Error('The camera is not ready yet.')
	const canvas = document.createElement('canvas')
	canvas.width = video.videoWidth
	canvas.height = video.videoHeight
	const context = canvas.getContext('2d')
	if (!context) throw new Error('Could not capture the camera frame.')
	context.drawImage(video, 0, 0, canvas.width, canvas.height)
	const dataUrl = canvas.toDataURL(type, quality)
	const [header, data] = dataUrl.split(',')
	const binary = atob(data)
	const bytes = new Uint8Array(binary.length)
	for (let index = 0; index < binary.length; index += 1) bytes[index] = binary.charCodeAt(index)
	return new Blob([bytes], { type: header.match(/data:(.*);base64/)?.[1] ?? type })
}
