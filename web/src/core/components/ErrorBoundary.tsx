import { Component, ErrorInfo, ReactNode } from 'react';

interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
}

export default class ErrorBoundary extends Component<{ children: ReactNode }, ErrorBoundaryState> {
  state: ErrorBoundaryState = {
    hasError: false,
    error: null,
  };

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    // You can send error details to an external monitoring service here.
    console.error('Unhandled error caught by ErrorBoundary:', error, errorInfo);
  }

  handleReload = () => {
    window.location.reload();
  };

  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-slate-50 p-4 text-slate-900 dark:bg-slate-950 dark:text-slate-100">
          <div className="rounded-3xl border border-slate-200 bg-white p-8 shadow-2xl shadow-slate-200/40 dark:border-slate-700 dark:bg-slate-900 dark:shadow-slate-950/40">
            <h1 className="mb-4 text-2xl font-semibold">Something went wrong</h1>
            <p className="mb-6 max-w-xl text-sm leading-6 text-slate-600 dark:text-slate-300">
              An unexpected error occurred while rendering the app. Refresh the page to continue, or contact support if the issue persists.
            </p>
            <button
              type="button"
              onClick={this.handleReload}
              className="rounded-full bg-slate-900 px-5 py-3 text-sm font-semibold text-white transition hover:bg-slate-700 dark:bg-slate-100 dark:text-slate-950 dark:hover:bg-slate-200"
            >
              Reload page
            </button>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}
