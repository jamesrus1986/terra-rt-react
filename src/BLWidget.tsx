import React from 'react';
import { Platform, requireNativeComponent, type ViewProps } from 'react-native';
import type { SuccessfulConnectionEvent } from './BLWidgetNativeComponent';

export interface BLWidgetProps extends ViewProps {
  withCache?: boolean;
  onSuccessfulConnection?: (event: SuccessfulConnectionEvent) => void;
}

const BLWidgetNative =
  Platform.OS === 'ios'
    ? requireNativeComponent<BLWidgetProps>('BLWidget')
    : () => null;

export const BLWidget: React.FC<BLWidgetProps> = (props) => {
  if (Platform.OS !== 'ios') {
    return null;
  }

  return <BLWidgetNative {...props} />;
};
