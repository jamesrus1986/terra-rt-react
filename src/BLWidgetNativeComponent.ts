import type { ViewProps } from 'react-native';
import type { HostComponent } from 'react-native';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { DirectEventHandler } from 'react-native/Libraries/Types/CodegenTypes';

export interface SuccessfulConnectionEvent {
  success: boolean;
}

export interface NativeProps extends ViewProps {
  withCache?: boolean;
  onSuccessfulConnection?: DirectEventHandler<SuccessfulConnectionEvent>;
}

export default codegenNativeComponent<NativeProps>('BLWidget', {
  excludedPlatforms: ['android'],
}) as HostComponent<NativeProps>;
