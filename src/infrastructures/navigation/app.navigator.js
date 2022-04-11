import React from "react";
import { HomeContextProvider } from "../../services/app/app.context";
import {
  CardStyleInterpolators,
  createStackNavigator,
} from "@react-navigation/stack";
import { HomeNavigator } from "./home.navigator";
import { SettingsScreen } from "../../features/settings/settings.screen";
import { ChatScreen } from "../../features/chats/chat.screen";
import { VideoCallScreen } from "../../features/calls/call-video.screen";
import { ChatContextProvider } from "../../services/chat/chat.context";

const Stack = createStackNavigator();

const getChatScreen = (route, navigation) => {
  return (
    <ChatContextProvider route={route} navigation={navigation}>
      <ChatScreen navigation={navigation} />
    </ChatContextProvider>
  );
};

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
          <Stack.Screen
            name="ChatDetail"
            component={({ route, navigation }) =>
              getChatScreen(route, navigation)
            }
          />
          <Stack.Screen name="VideoCall" component={VideoCallScreen} />
        </Stack.Navigator>
      </HomeContextProvider>
    </>
  );
};
