import React from "react";
import styled from "styled-components/native";
import { Text } from "../../../components/typography/text.component";
import { colors } from "../../../infrastructures/theme/colors";
import Ionicons from "react-native-vector-icons/Ionicons";

const Container = styled.View`
  height: 50px;
  width: 100%;
  align-items: flex-start;
  justify-content: center;
  padding: ${(props) => props.theme.spaces[2]};
`;

const TextContainer = styled.View`
  flex: 1;
  align-items: flex-start;
  justify-content: center;
  margin-left: ${(props) => props.theme.spaces[2]};
  margin-top: 3px;
`;

const Iconfront = styled(Ionicons).attrs({
  color: colors.ui.primary,
  size: 24,
})`
  margin-left: ${(props) => props.theme.spaces[2]};
`;

const IconBack = styled(Ionicons).attrs({
  color: colors.ui.gray,
  size: 24,
  name: "md-chevron-forward",
})`
  margin-left: ${(props) => props.theme.spaces[2]};
`;

const Button = styled.TouchableOpacity`
  align-items: flex-start;
  justify-content: center;
  flex: 1;
  flex-direction: row;
`;

export const SettingComponent = ({ title, onClick, frontIcon, backIcon }) => {
  console.log(backIcon);
  return (
    <Container>
      <Button onPress={onClick}>
        {frontIcon && <Iconfront name={frontIcon} />}
        <TextContainer>
          <Text variant="hint" color={colors.text.black}>
            {title}
          </Text>
        </TextContainer>
        {backIcon && <IconBack />}
      </Button>
    </Container>
  );
};
