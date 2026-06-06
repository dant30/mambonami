import { AlertTriangle, Trash2 } from "lucide-react";
import Button from "./Button";
import { Modal, ModalBody, ModalFooter } from "./Modal";

interface ConfirmationModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
  title: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  variant?: "danger" | "warning" | "info";
  isLoading?: boolean;
}

export function ConfirmationModal({
  isOpen,
  onClose,
  onConfirm,
  title,
  message,
  confirmText = "Confirm",
  cancelText = "Cancel",
  variant = "danger",
  isLoading = false,
}: ConfirmationModalProps) {
  const iconMap = {
    danger: <Trash2 className="h-6 w-6 text-rose-600" />,
    warning: <AlertTriangle className="h-6 w-6 text-amber-600" />,
    info: <AlertTriangle className="h-6 w-6 text-blue-600" />,
  };

  const buttonVariantMap = {
    danger: 'destructive' as const,
    warning: 'secondary' as const,
    info: 'secondary' as const,
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} size="sm" showCloseButton={false}>
      <ModalBody className="py-8 text-center">
        <div className="mx-auto mb-5 flex h-16 w-16 items-center justify-center rounded-full bg-slate-50 dark:bg-slate-800/50">
          {iconMap[variant]}
        </div>
        <h3 className="mb-2 text-xl font-bold text-slate-900 dark:text-slate-100">{title}</h3>
        <p className="text-base text-slate-500 dark:text-slate-400">{message}</p>
      </ModalBody>
      <ModalFooter className="border-none bg-transparent pb-8">
        <div className="grid w-full grid-cols-2 gap-3">
          <Button type="button" onClick={onClose} variant="ghost" disabled={isLoading}>
            {cancelText}
          </Button>
          <Button 
            type="button"
            onClick={onConfirm} 
            variant={buttonVariantMap[variant]} 
            disabled={isLoading}
          >
            {confirmText}
          </Button>
        </div>
      </ModalFooter>
    </Modal>
  );
}