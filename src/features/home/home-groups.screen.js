import React, { useState } from "react";
import { PersonComponent } from "./components/person.component";
import { SectionComponent } from "./components/section.component";

export const HomeGroupsScreen = ({ groups }) => {
  const [showContent, setShowContent] = useState(true);

  const onClick = () => {
    const show = !showContent;
    setShowContent(show);
  };

  return (
    <>
      <SectionComponent
        showContent={showContent}
        title={`Groups ${groups.length - 1}`}
        onClick={onClick}
      />
      {showContent &&
        groups.map((data, index) => {
          return <PersonComponent PersonInfo={data} key={`data-${index}`} />;
        })}
    </>
  );
};
