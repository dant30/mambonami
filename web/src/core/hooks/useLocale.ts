// web/src/core/hooks/useLocale.ts
import { useCallback, useState } from 'react';
import en from '../locale/en.json';
import sw from '../locale/sw.json';

type LocaleKey = 'en' | 'sw';

const locales: Record<LocaleKey, typeof en> = {
  en,
  sw,
};

export const useLocale = (locale: LocaleKey = 'en') => {
  const [currentLocale, setCurrentLocale] = useState<LocaleKey>(locale);

  const t = useCallback(
    (path: string, defaultValue?: string): string => {
      const keys = path.split('.');
      let value: any = locales[currentLocale];

      for (const key of keys) {
        if (value && typeof value === 'object' && key in value) {
          value = value[key];
        } else {
          return defaultValue || path;
        }
      }

      return typeof value === 'string' ? value : defaultValue || path;
    },
    [currentLocale]
  );

  const switchLocale = useCallback((newLocale: LocaleKey) => {
    setCurrentLocale(newLocale);
    localStorage.setItem('locale', newLocale);
  }, []);

  const getLocale = useCallback(() => currentLocale, [currentLocale]);

  return {
    t,
    switchLocale,
    getLocale,
    currentLocale,
  };
};
