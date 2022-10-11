/* eslint-disable react/prop-types */
import { React, useState } from 'react';
import { View } from 'react-native';
import { SectionComponent } from './component/sectionComponent';
import { PersonComponent } from './component/personComponent';

export const FriendSection = ({ title, items, onNavigate, onAdd, state }) => {
  const [showContent, setShowContent] = useState(true);
  const onClick = () => {
    const show = !showContent;
    setShowContent(show);
  };
  return (
    <View>
      <SectionComponent
        showContent={showContent}
        title={`${title} ${
          title == 'Groups' ? items.length - 1 : items.length
        }`}
        onClick={onClick}
      />
      {showContent &&
        items.map((data, index) => {
          return (
            <PersonComponent
              CELLInfo={data}
              key={`data-${index}`}
              onNavigate={onNavigate}
              visible={onAdd}
              state = {state}
            />
          );
        })}
    </View>
  );
};
