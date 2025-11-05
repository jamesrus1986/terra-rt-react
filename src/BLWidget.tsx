import React from 'react';
import { requireNativeComponent, Platform, View } from 'react-native';
import type { ViewProps } from 'react-native';

export interface SuccessfulConnectionEvent {
  success: boolean;
}

export interface BLWidgetProps extends ViewProps {
  withCache?: boolean;
  onSuccessfulConnection?: (event: {
    nativeEvent: SuccessfulConnectionEvent;
  }) => void;
}

const NativeBLWidget =
  Platform.OS === 'ios'
    ? requireNativeComponent<BLWidgetProps>('BLWidget')
    : View;

export function BLWidget(props: BLWidgetProps) {
  if (Platform.OS !== 'ios') {
    return null;
  }

  return <NativeBLWidget {...props} />;
}
