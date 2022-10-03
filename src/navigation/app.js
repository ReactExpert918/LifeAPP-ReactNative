import React from "react";
import { createStackNavigator } from "@react-navigation/stack";
import { APP_NAVIGATION } from "../constants/app";
import { FriendScreen } from "../screens/friend";

const Stack = createStackNavigator();

export const AppNavigator = () => {
    return(
        <>
            <Stack.Navigator
                screenOptions={{ headerShown: false, gestureEnabled: false }}
            >
                <Stack.Screen name="main" component={FriendScreen} />
            </Stack.Navigator>
        </>
    )
};
