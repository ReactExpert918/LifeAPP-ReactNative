import React, { useContext } from "react";
import { SafeArea } from "../../components/utils/safe-area.component";
import { HomeHeaderComponent } from "./components/header.component";
import styled from "styled-components/native";
import { SearchbarComponent } from "./components/search-bar.component";
import { PersonComponent } from "./components/person.component";
import { HomeContext } from "../../services/app/app.context";
import { HomeGroupsScreen } from "./home-groups.screen";

const StatusBar = styled.View`
  background-color: ${(props) => props.theme.colors.ui.primary};
  position: absolute;
  left: 0px;
  top: 0px;
  width: 100%;
  height: 100%;
`;

const MainContainer = styled.View`
  flex: 1;
  background-color: ${(props) => props.theme.colors.bg.primary};
`;

const ScrollContainer = styled.ScrollView`
  flex: 1;
  margin-horizontal: 10px;
`;

export const HomeScreen = () => {
  const { userInfo, groups, friends } = useContext(HomeContext);
  return (
    <>
      <StatusBar />
      <SafeArea>
        <HomeHeaderComponent />
        <SearchbarComponent />
        <MainContainer>
          <ScrollContainer>
            {userInfo && <PersonComponent PersonInfo={userInfo} />}
            {groups.length > 0 && <HomeGroupsScreen groups={groups} />}
          </ScrollContainer>
        </MainContainer>
      </SafeArea>
    </>
  );
};
