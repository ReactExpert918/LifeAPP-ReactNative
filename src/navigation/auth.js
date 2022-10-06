import React from "react";
import { createStackNavigator } from "@react-navigation/stack";
import { AuthScreen } from "../screens/auth";
import { FriendScreen } from "../screens/friend";

const Stack = createStackNavigator();

export const AuthNavigator = () => (
  <Stack.Navigator
    screenOptions={{ headerShown: false, gestureEnabled: false }}
  >
    <Stack.Screen name="Login" component={AuthScreen} />
  </Stack.Navigator>
);
