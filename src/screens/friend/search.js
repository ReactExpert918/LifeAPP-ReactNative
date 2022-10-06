import React, { useEffect, useState } from "react"
import { Text, Image, View, Dimensions } from "react-native"
import styled from "styled-components/native";
import { ContainerComponent } from "../../components/container.component";
import { FriendHeader } from "./component/friendHeader";
import { FriendSection } from "./friendSection";
import { searchStyle } from "./style"
import { colors } from "../../assets/colors";
import { images } from "../../assets/pngs";
import { Searchbar } from "react-native-paper";
import Ionicons from "react-native-vector-icons/Ionicons";
import { ChatExpand } from "./component/chatExpand";

const Button = styled.TouchableOpacity`
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  border-color: ${colors.bg.gray};
  border-width: ${(props) => (!props.isSelected ? "1px;" : "0px;")};
  border-radius: 12px;
  background-color: ${(props) =>
    props.isSelected
      ? colors.ui.primary
      : colors.bg.primary};
`;

const IconCheck = styled(Ionicons).attrs({
  color: colors.ui.white,
  size: 16,
  name: "md-checkmark",
})``;

const SearchOptions = {
  username: "Username",
  phone: "Phone Number",
};

const EmptyImage = styled.Image`
  width: ${Dimensions.get('window').height/5*2};
  height: ${Dimensions.get('window').height/5*1.5};
`;

const EmptyText = styled.Text`
  color: ${colors.text.gray};
  text-align: center;
  font-size: 20px;
  font-weight: 400;
  margin-bottom: 20px;
`;

export const FriendSearchScreen = ({ navigation }) => {
    const [searchOption, setSearchOption] = useState(SearchOptions.username);
    const [searchKeyword, setSearchKeyword] = useState("");
    let friends = [{username: "James", type: 'search'}];
    const [isExpandVisible, isSetExpandVisibily] = useState(false); 
    const onBack = () => {
        navigation.goBack()
    }
    return(
        <ContainerComponent>
            <FriendHeader title="Search Friends" back={onBack}/>
            <View style={searchStyle.divider}></View>
            <View style={searchStyle.mainContainer}>
                <View style={searchStyle.topContainer}>
                    <Button
                        isSelected={searchOption == SearchOptions.username}
                        onPress={() => setSearchOption(SearchOptions.username)}
                    >
                        {searchOption == SearchOptions.username && <IconCheck />}
                    </Button>
                    <Text style={searchStyle.text} >
                        {SearchOptions.username}
                    </Text>
                    <View style={searchStyle.space}></View>
                    <Button
                        isSelected={searchOption == SearchOptions.phone}
                        onPress={() => setSearchOption(SearchOptions.phone)}
                    >
                        {searchOption == SearchOptions.phone && <IconCheck />}
                    </Button>
                    <Text style={searchStyle.text} >
                        {SearchOptions.phone}
                    </Text>
                </View>
                <View style={searchStyle.container}>
                    <Searchbar
                        style={searchStyle.searchStyle}
                        clearAccessibilityLabel="Cancel"
                        placeholder="Search"
                        value={searchKeyword}
                        onChangeText={(text) => setSearchKeyword(text)}
                        onSubmitEditing={() => console.log("Search")}
                    />
                </View>
                {
                    searchKeyword == "james" ? 
                        (<View>
                            <FriendSection 
                                title="Showing Results"
                                items={friends}
                                onNavigate={null}
                                visible = {isSetExpandVisibily}
                            />
                        </View>) :
                        (<View
                            style={{
                                flex: 1,
                                justifyContent: "center",
                                alignItems: "center",
                                backgroundColor: colors.bg.primary,
                                width: "100%",
                            }}
                        >
                            <EmptyText>
                            {
                                searchKeyword !== "Richard" ? (`Search friends using their username ${"\n"}  or phone number`) : 
                                (`No user is available by that username`)
                            }
                            </EmptyText>
                           
                            {
                                searchKeyword == "Richard" ? 
                                <EmptyImage
                                    source={images.img_search_no}
                                    resizeMode="contain"
                                />  : 
                                <EmptyImage
                                    source={images.img_search_bg}
                                    resizeMode="contain"
                                />
                            }
                            
                        </View>)
                }
            </View>
            {
                isExpandVisible == false ? (<ChatExpand visible={isSetExpandVisibily} />) : null
            }
        </ContainerComponent>
    )
}