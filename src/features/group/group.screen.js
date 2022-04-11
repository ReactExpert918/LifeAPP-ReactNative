import React from "react";
import { SafeArea } from "../../components/utils/safe-area.component";
import styled from "styled-components/native";
import { GroupHeaderComponent } from "./components/header.component";

const StatusBar = styled.View`
  background-color: ${(props) => props.theme.colors.ui.primary};
  position: absolute;
  left: 0px;
  top: 0px;
  width: 100%;
  height: 30%;
`;

const MainContainer = styled.View`
  flex: 1;
  background-color: ${(props) => props.theme.colors.bg.primary};
`;

const AvataContainer = styled.View`
  width: 80px;
  height: 80px;
  border-radius: 40px;
  background-color: ${(props) => props.theme.colors.bg.lightgray};
  align-items: center;
  justify-content: center;
`;

const AvataImage = styled.Image`
  width: 80px;
  height: 80px;
  border-radius: 40px;
`;

const IconImage = styled.Image`
  width: 20px;
  height: 20px;
  position: absolute;
  left: ${(props) => (props.center ? "30px" : "60px")};
  top: ${(props) => (props.center ? "30px" : "60px")};
`;

export const GroupScreen = ({ navigation }) => {
  const onClickClose = () => {
    navigation.goBack();
  };

  const onClickDone = () => {};

  return (
    <>
      <StatusBar />
      <SafeArea>
        <GroupHeaderComponent
          onClickClose={onClickClose}
          onClickDone={onClickDone}
        />
        <MainContainer></MainContainer>
      </SafeArea>
    </>
  );
};
