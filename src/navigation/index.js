import React from 'react';
import { NavigationContainer } from '@react-navigation/native';

import AuthNavigator from './auth';
import AppNavigator from './app';
import { Splash } from '../screens/splash';

export const RootNavigation = () => {
  return (
    <NavigationContainer>
      <Splash />
      <AuthNavigator />
      <AppNavigator />
    </NavigationContainer>
  );
};
