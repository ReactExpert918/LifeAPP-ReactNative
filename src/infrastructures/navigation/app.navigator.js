import React from "react";
import { HomeContextProvider } from "../../services/app/app.context";
import {
  CardStyleInterpolators,
  createStackNavigator,
} from "@react-navigation/stack";
import { HomeNavigator } from "./home.navigator";
import { SettingsScreen } from "../../features/settings/settings.screen";

const Stack = createStackNavigator();

export const AppNavigator = () => {
  return (
    <>
      <HomeContextProvider>
        <Stack.Navigator
          screenOptions={{
            headerShown: false,
            gestureEnabled: false,
            cardStyleInterpolator: CardStyleInterpolators.forVerticalIOS,
          }}
        >
          <Stack.Screen name="Home" component={HomeNavigator} />
          <Stack.Screen name="Settings" component={SettingsScreen} />
        </Stack.Navigator>
      </HomeContextProvider>
    </>
  );
};
