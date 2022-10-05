import React from "react";
import { createStackNavigator } from "@react-navigation/stack";
import { APP_NAVIGATION } from "../constants/app";
import { FriendScreen } from "../screens/friend";
import { ChatScreen } from "../screens/chat";
import { ChatDetailsScreen } from "../screens/chat/chatDetails";

const Stack = createStackNavigator();

export const AppNavigator = () => {
    return(
        <>
            <Stack.Navigator
                screenOptions={{ headerShown: false, gestureEnabled: false }}
            >
                <Stack.Screen name={APP_NAVIGATION.chat} component={ChatScreen} />
                <Stack.Screen name="main" component={FriendScreen} />
            </Stack.Navigator>
        </>
    )
};
