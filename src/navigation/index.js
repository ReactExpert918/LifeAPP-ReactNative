import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { AuthNavigator } from './auth';
// import { FriendNavigator } from './app';

export const Navigator = () => {
  return (
    <NavigationContainer>
      <AuthNavigator />
      {/* <FriendNavigator /> */}
    </NavigationContainer>
  );
};
