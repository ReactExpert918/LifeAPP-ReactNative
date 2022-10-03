import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { AuthNavigator } from './auth';

export const Navigator = () => {
  return (
    <NavigationContainer>
      <AuthNavigator />
    </NavigationContainer>
  );
};
