import React, { useState } from "react";
import { SafeArea } from "../../components/utils/safe-area.component";
import styled from "styled-components/native";
import { GroupHeaderComponent } from "./components/header.component";
import { images } from "../../images";
import { TouchableOpacity } from "react-native";
import { Text } from "../../components/typography/text.component";
import { colors } from "../../infrastructures/theme/colors";
import { TextInput } from "react-native-paper";
import { Spacer } from "../../components/spacer/spacer.component";

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

const TopContainer = styled.View`
  width: 100%;
  padding: ${(props) => props.theme.spaces[3]};
  flex-direction: row;
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

const InputContainer = styled.View`
  flex: 1;
  align-items: flex-start;
  justify-content: center;
  margin-left: ${(props) => props.theme.spaces[3]};
`;

const Input = styled(TextInput)`
  width: 100%;
  height: 40px;
  margin-top: ${(props) => props.theme.spaces[2]};
`;

const Divider = styled.View`
  width: 100%;
  height: 1px;
  background-color: ${(props) => props.theme.colors.bg.black};
`;

const MemberIndicatorContainer = styled.View`
  width: 100%;
  padding: ${(props) => props.theme.spaces[3]};
  align-items: flex-start;
  justify-content: center;
`;

export const GroupScreen = ({ navigation }) => {
  const [image_path, setImage_path] = useState(null);
  const [groupName, setGroupName] = useState(null);
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
        <MainContainer>
          <TopContainer>
            <TouchableOpacity>
              <AvataContainer>
                {image_path && <AvataImage source={{ uri: image_path }} />}
                <IconImage
                  source={images.ic_camera}
                  center={image_path == null}
                />
              </AvataContainer>
            </TouchableOpacity>
            <InputContainer>
              <Text variant="label" color={colors.text.gray}>
                Group Name
              </Text>
              <Input
                value={groupName}
                placeholder="Eg.Dev Group"
                autoCapitalize="none"
                onChangeText={(text) => setGroupName(text)}
              />
            </InputContainer>
          </TopContainer>
          <Divider />
          <MemberIndicatorContainer>
            <Text variant="label" color={colors.text.black}>
              Members
            </Text>
          </MemberIndicatorContainer>
          <Divider />
          <Spacer size="large" />
        </MainContainer>
      </SafeArea>
    </>
  );
};
