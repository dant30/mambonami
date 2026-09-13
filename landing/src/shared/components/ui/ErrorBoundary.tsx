import React, { Component, ErrorInfo, ReactNode } from 'react'
import { AlertTriangle, RotateCcw } from 'lucide-react'

export interface ErrorBoundaryProps {
  children: ReactNode
  fallback?: ReactNode
  onReset?: () => void
}

export interface ErrorBoundaryState {
  hasError: boolean
  error: Error | null
}

export class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  override state: ErrorBoundaryState = {
    hasError: false,
    error: null,
  }

  public static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error }
  }

  override componentDidCatch(error: Error, errorInfo: ErrorInfo): void {
    console.error('KaziLink ErrorBoundary caught an error:', error, errorInfo)
  }

  public handleReset = (): void => {
    this.setState({ hasError: false, error: null })
    if (this.props.onReset) {
      this.props.onReset()
    }
  }

  override render(): ReactNode {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback
      }

      return (
        <div className="min-h-[280px] flex items-center justify-center p-6">
          <div className="w-full max-w-md rounded-2xl border border-rose-200 bg-white p-6 shadow-md text-center">
            <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-rose-50 text-rose-600 mb-4">
              <AlertTriangle className="h-6 w-6" />
            </div>
            <h3 className="text-base font-black text-slate-900">Something went wrong</h3>
            <p className="mt-1 text-xs text-slate-500">
              An unexpected error occurred while rendering this section.
            </p>

            {this.state.error && (
              <pre className="mt-4 p-3 rounded-xl bg-slate-50 border border-slate-200 text-[11px] text-slate-600 text-left overflow-x-auto max-h-28">
                {this.state.error.message}
              </pre>
            )}

            <div className="mt-6 flex justify-center">
              <button
                type="button"
                onClick={this.handleReset}
                className="inline-flex items-center gap-2 rounded-xl bg-[#0A2540] px-4 py-2 text-xs font-bold text-white hover:bg-[#153B64] transition-colors shadow-sm"
              >
                <RotateCcw className="h-3.5 w-3.5" />
                Try again
              </button>
            </div>
          </div>
        </div>
      )
    }

    return this.props.children
  }
}
