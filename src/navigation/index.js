import React from 'react';
import { useSelector } from 'react-redux';
import { NavigationContainer } from '@react-navigation/native';
import SplashScreen from '../screens/splash';
import { AuthNavigator } from './auth';
// import { FriendNavigator } from './app';
import { AppNavigator } from './app';

export const Navigator = () => {
  const { isSplash, isLogin } = useSelector((state) => state.Splash);
  console.log(isSplash, isLogin);

  return (
    <NavigationContainer>
      {isSplash ? (
        <SplashScreen />
      ) : isLogin ? (
        <AuthNavigator />
      ) : (
        <AppNavigator />
      )}
    </NavigationContainer>
  );
};
