// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

import { Example } from "./Example";

import styles from "./Example.module.css";
import { useTranslation } from 'react-i18next';

export type ExampleModel = {
    text: string;
    value: string;
};

interface Props {
    onExampleClicked: (value: string) => void;
}

export const ExampleList = ({ onExampleClicked }: Props) => {
    const { t } = useTranslation();

    const EXAMPLES: ExampleModel[] = [
        { text: t('example_1'), value: t('example_1') },
        { text: t('example_2'), value: t('example_2') },
        { text: t('example_3'), value: t('example_3') }
    ];

    return (
        <ul className={styles.examplesNavList}>
            {EXAMPLES.map((x, i) => (
                <li key={i}>
                    <Example text={x.text} value={x.value} onClick={onExampleClicked} />
                </li>
            ))}
        </ul>
    );
};
