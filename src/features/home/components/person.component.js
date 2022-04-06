import React from "react";
import styled from "styled-components/native";
import { Text } from "../../../components/typography/text.component";
import { images } from "../../../images";
import { colors } from "../../../infrastructures/theme/colors";

const Container = styled.View`
  height: 80px;
  width: 100%;
  align-items: center;
  justify-content: center;
  flex-direction: row;
  padding: ${(props) => props.theme.spaces[2]};
`;

const HeaderImage = styled.Image`
  width: 48px;
  height: 48px;
  border-radius: 24px;
  margin-right: ${(props) => props.theme.spaces[2]};
`;

const TextContainer = styled.View`
  flex: 1;
  align-items: flex-start;
  justify-content: center;
`;

export const PersonComponent = ({ PersonInfo }) => {
  const { image_uri, title, message, name, isGroup } = PersonInfo;
  return (
    <Container>
      {isGroup ? (
        <HeaderImage source={images.ic_create_group} />
      ) : image_uri ? (
        <HeaderImage source={{ uri: image_uri }} />
      ) : (
        <HeaderImage source={images.ic_default_profile} />
      )}
      <TextContainer>
        {title && (
          <>
            <Text variant="label" color={colors.text.black}>
              {title}
            </Text>
            <Text variant="hint" color={colors.text.gray}>
              {message}
            </Text>
          </>
        )}
        {name && (
          <Text variant="label" color={colors.text.black}>
            {name}
          </Text>
        )}
      </TextContainer>
    </Container>
  );
};
