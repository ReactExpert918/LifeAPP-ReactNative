import React, { useState } from 'react';
import { View } from 'react-native';
import { Searchbar } from 'react-native-paper';
import { chatSearchComponentStyle } from './chatComponentStyled';

export const SearchbarComponent = () => {
  const [searchKeyword, setSearchKeyword] = useState('');

  return (
    <View style={chatSearchComponentStyle.container}>
      <Searchbar
        style={chatSearchComponentStyle.searchStyle}
        clearAccessibilityLabel="Cancel"
        placeholder="Search"
        value={searchKeyword}
        onChangeText={(text) => setSearchKeyword(text)}
        onSubmitEditing={() => console.log('Search')}
        inputStyle={{ padding: 0 }}
      />
    </View>
  );
};
