import React from 'react';
import {
  Platform,
  type ViewProps,
  type NativeSyntheticEvent,
} from 'react-native';
import BLWidgetNativeComponent, {
  type SuccessfulConnectionEvent,
} from './BLWidgetNativeComponent';

export interface BLWidgetProps extends ViewProps {
  withCache?: boolean;
  onSuccessfulConnection?: (event: SuccessfulConnectionEvent) => void;
}

export const BLWidget: React.FC<BLWidgetProps> = ({
  onSuccessfulConnection,
  ...props
}) => {
  if (Platform.OS !== 'ios') {
    return null;
  }

  const handleSuccessfulConnection = (
    event: NativeSyntheticEvent<SuccessfulConnectionEvent>
  ) => {
    if (onSuccessfulConnection) {
      onSuccessfulConnection(event.nativeEvent);
    }
  };

  return (
    <BLWidgetNativeComponent
      {...props}
      onSuccessfulConnection={handleSuccessfulConnection}
    />
  );
};
