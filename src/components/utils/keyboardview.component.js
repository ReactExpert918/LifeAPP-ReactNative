import React from "react";
import { KeyboardAwareScrollView } from "react-native-keyboard-aware-scroll-view";

export const KeyboardView = ({ children }) => {
  return (
    <KeyboardAwareScrollView contentContainerStyle={{ flex: 1 }}>
      {children}
    </KeyboardAwareScrollView>
  );
};
