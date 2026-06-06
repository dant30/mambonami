import { Fragment, useState, type ComponentPropsWithoutRef } from 'react';
import { Combobox, Transition } from '@headlessui/react';
import { Check, ChevronDown, Search } from 'lucide-react';
import { cn } from '../../../lib/utils';

interface Option {
  value: string | number;
  label: string;
  subtitle?: string;
}

interface SearchableSelectProps extends Omit<ComponentPropsWithoutRef<'select'>, 'value' | 'defaultValue' | 'size' | 'multiple'> {
  options: Option[];
  value?: string | number;
  onValueChange?: (value: string) => void;
  placeholder?: string;
  label?: string;
  error?: string;
}

export function SearchableSelect({
  options,
  value,
  onValueChange,
  placeholder = 'Select an option',
  label,
  error,
  className,
  onChange: nativeOnChange,
  ...props
}: SearchableSelectProps) {
  const [query, setQuery] = useState('');

  const shouldUseNativeSelect = value === undefined || onValueChange === undefined;
  const selectedOption = options.find((opt) => String(opt.value) === String(value));
  const currentValue = value !== undefined ? String(value) : '';

  const filteredOptions =
    query === ''
      ? options
      : options.filter((option) =>
          option.label
            .toLowerCase()
            .replace(/\s+/g, '')
            .includes(query.toLowerCase().replace(/\s+/g, '')) ||
          option.subtitle
            ?.toLowerCase()
            .replace(/\s+/g, '')
            .includes(query.toLowerCase().replace(/\s+/g, '')),
        );

  const inputProps = {
    id: props.id,
    name: props.name,
    disabled: props.disabled,
  } as const;

  if (shouldUseNativeSelect) {
    return (
      <div className="w-full">
        {label && <span className="form-label mb-1.5 block">{label}</span>}
        <select
          className={cn(
            'form-select h-11 w-full rounded-xl border px-3.5 text-[15px] text-slate-900 shadow-sm transition duration-200 focus:border-brand-500 focus:ring-brand-500/10 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-100',
            error && 'border-rose-500 focus:ring-rose-500/10',
            className,
          )}
          value={currentValue}
          onChange={(event) => {
            nativeOnChange?.(event as any);
            onValueChange?.(event.target.value);
          }}
          {...props}
        >
          {options.map((option) => (
            <option key={String(option.value)} value={String(option.value)}>
              {option.label}
            </option>
          ))}
        </select>
        {error && <p className="form-error mt-1">{error}</p>}
      </div>
    );
  }

  return (
    <div className="w-full">
      <Combobox
        value={currentValue}
        onChange={(val) => {
          onValueChange?.(String(val ?? ''));
          nativeOnChange?.({
            target: { value: String(val ?? '') },
            currentTarget: { value: String(val ?? '') },
          } as any);
        }}
      >
        {({ open }) => (
          <div className={cn('relative mt-1', open ? 'z-50' : 'z-auto')}>
            {label && <span className="form-label mb-1.5 block">{label}</span>}
            <div className="relative">
              <div className="relative w-full">
                <Combobox.Input
                  className={cn(
                    'relative flex w-full h-11 items-center cursor-default rounded-xl border bg-white pl-11 pr-10 text-left text-[15px] font-medium shadow-sm transition-all duration-200 focus:outline-none focus:ring-4 dark:bg-slate-900 dark:text-slate-100',
                    error
                      ? 'border-rose-500 focus:ring-rose-500/10'
                      : 'border-slate-200 hover:border-slate-300 hover:bg-slate-50/50 focus:border-brand-500 focus:ring-brand-500/10 dark:border-slate-700 dark:hover:border-slate-600 dark:hover:bg-slate-800/50',
                    className,
                  )}
                  displayValue={(val: string) =>
                    selectedOption?.label || options.find((opt) => String(opt.value) === String(val))?.label || ''
                  }
                  placeholder={placeholder}
                  onChange={(event) => setQuery(event.target.value)}
                  {...inputProps}
                />
                <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4">
                  <Search className="h-4 w-4 text-slate-400" />
                </div>
                <Combobox.Button className="absolute inset-y-0 right-0 flex items-center pr-3">
                  <ChevronDown
                    className={cn(
                      'h-4 w-4 text-slate-400 transition-transform duration-200',
                      open && 'rotate-180',
                    )}
                    aria-hidden="true"
                  />
                </Combobox.Button>
              </div>

              <Transition
                as={Fragment}
                leave="transition ease-in duration-100"
                leaveFrom="opacity-100"
                leaveTo="opacity-0"
                afterLeave={() => setQuery('')}
              >
                <Combobox.Options className="absolute z-50 mt-2 max-h-72 w-full overflow-hidden rounded-2xl bg-white shadow-[0_20px_50px_rgba(0,0,0,0.15)] ring-1 ring-black/5 focus:outline-none dark:bg-slate-800">
                  {filteredOptions.length === 0 && query !== '' ? (
                    <div className="relative cursor-default select-none py-6 px-4 text-center text-slate-500">
                      Nothing found.
                    </div>
                  ) : filteredOptions.length === 0 ? (
                    <div className="relative cursor-default select-none py-6 px-4 text-center text-slate-500">
                      No options available
                    </div>
                  ) : (
                    <div className="divide-y divide-slate-50 dark:divide-slate-700/50">
                      {filteredOptions.map((option) => (
                        <Combobox.Option
                          key={String(option.value)}
                          className={({ active }) =>
                            cn(
                              'relative cursor-default select-none py-2.5 pl-10 pr-4 transition-all duration-200',
                              active
                                ? 'bg-brand-50/50 text-brand-900 dark:bg-brand-500/10 dark:text-brand-50'
                                : 'text-slate-700 dark:text-slate-300',
                            )
                          }
                          value={String(option.value)}
                        >
                          {({ selected, active }) => (
                            <>
                              <div className="flex flex-col gap-0.5">
                                <span
                                  className={cn(
                                    'block truncate text-sm transition-colors',
                                    selected
                                      ? 'font-bold text-brand-700 dark:text-brand-400'
                                      : 'font-medium',
                                  )}
                                >
                                  {option.label}
                                </span>
                                {option.subtitle && (
                                  <span
                                    className={cn(
                                      'text-[11px] uppercase tracking-wider transition-colors',
                                      active
                                        ? 'text-brand-600/70 dark:text-brand-400/70'
                                        : 'text-slate-400',
                                    )}
                                  >
                                    {option.subtitle}
                                  </span>
                                )}
                              </div>

                              {selected && (
                                <span className="absolute inset-y-0 left-0 flex items-center pl-3.5 text-brand-600">
                                  <Check className="h-3.5 w-3.5 stroke-[3]" aria-hidden="true" />
                                </span>
                              )}

                              {active && !selected && (
                                <div className="absolute inset-y-0 left-0 w-1 bg-brand-500 rounded-r-full" />
                              )}
                            </>
                          )}
                        </Combobox.Option>
                      ))}
                    </div>
                  )}
                </Combobox.Options>
              </Transition>
            </div>
          </div>
        )}
      </Combobox>
      {error && <p className="form-error mt-1.5 ml-1">{error}</p>}
    </div>
  );
}

SearchableSelect.displayName = 'SearchableSelect';
export default SearchableSelect;

