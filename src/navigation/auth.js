import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import { AuthScreen } from '../screens/auth';
import { LoginScreen } from '../screens/auth/login';
import { SignUpScreen } from '../screens/auth/signup';

const Stack = createStackNavigator();

export const AuthNavigator = () => (
  <Stack.Navigator
    screenOptions={{ headerShown: false, gestureEnabled: false }}
  >
    <Stack.Screen name="Auth" component={AuthScreen} />
    <Stack.Screen name="Login" component={LoginScreen} />
    <Stack.Screen name="SignUp" component={SignUpScreen} />
  </Stack.Navigator>
);
