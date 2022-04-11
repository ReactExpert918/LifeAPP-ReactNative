import React from "react";
import {
  createStackNavigator,
} from "@react-navigation/stack";

const Stack = createStackNavigator();

export const GroupNavigator = () => {
  return (
    <Stack.Navigator
      screenOptions={{
        headerShown: false,
        gestureEnabled: false,
        cardStyleInterpolator: CardStyleInterpolators.forVerticalIOS,
      }}
    >
      <Stack.Screen name="Home" component={HomeNavigator} />
      <Stack.Screen name="Settings" component={SettingsScreen} />
      <Stack.Screen
        name="ChatDetail"
        component={({ route, navigation }) => getChatScreen(route, navigation)}
      />
    </Stack.Navigator>
  );
};
