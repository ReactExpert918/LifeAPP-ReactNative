import React from "react";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { Text } from "react-native-paper";
import Ionicons from "react-native-vector-icons/Ionicons";
import { colors } from "../theme/colors";
import { HomeScreen } from "../../features/home/home.screen";
import { TouchableOpacity } from "react-native";
import { SafeArea } from "../../components/utils/safe-area.component";
import { firebaseSDK } from "../../libs/firebase";
import { useDispatch } from "react-redux";
import { LOGIN_ACTION } from "../../constants/redux";
import { HomeContextProvider } from "../../services/app/app.context";

const Tab = createBottomTabNavigator();

const TAB_ICONS = {
  Home: "md-home",
  Chats: "md-chatbubbles",
};

const tabBarIcon =
  (iconName) =>
  ({ size, color }) =>
    <Ionicons name={iconName} size={size} color={color} />;

const screenOptions = ({ route }) => {
  const iconName = TAB_ICONS[route.name];

  return {
    tabBarIcon: tabBarIcon(iconName),
    tabBarInactiveTintColor: colors.ui.gray,
    tabBarActiveTintColor: colors.ui.primary,
    headerShown: false,
  };
};

export const AppNavigator = () => {
  const dispatch = useDispatch();
  return (
    <>
      <HomeContextProvider>
        <Tab.Navigator screenOptions={screenOptions}>
          <Tab.Screen name="Home" component={HomeScreen} />
          <Tab.Screen
            name="Chats"
            component={() => (
              <SafeArea>
                <TouchableOpacity
                  onPress={() => dispatch({ type: LOGIN_ACTION.LOGOUT })}
                >
                  <Text>Sign Out</Text>
                </TouchableOpacity>
              </SafeArea>
            )}
          />
        </Tab.Navigator>
      </HomeContextProvider>
    </>
  );
};
