'use client';

import '@/app/globals.css';
import CardList from '@/components/card_list';
import { formatDateYyyymmdd } from '@/components/date_util';
import Footer from '@/components/footer';
import Header from '@/components/header';
import MainHeader from '@/components/main_header';
import Menu from '@/components/menu';
import { Area, Region } from '@/components/types';
import { promises as fs } from 'fs';
import type { GetStaticProps, InferGetStaticPropsType } from 'next';
import type { AppProps } from 'next/app';
import { Kosugi_Maru } from 'next/font/google';
import Head from 'next/head';
import { useEffect, useState } from 'react';

const kosugiMaru = Kosugi_Maru({
  weight: ['400'],
  subsets: ['latin'],
});

type Param = {
  regions: Region[];
  areas: Area[];
};

export const getStaticProps = (async (context) => {
  const file1 = await fs.readFile(process.cwd() + '/api/regions.json', 'utf8');
  const regions: Region[] = JSON.parse(file1);
  const file2 = await fs.readFile(process.cwd() + '/api/areas.json', 'utf8');
  const areas: Area[] = JSON.parse(file2);
  const param = { regions, areas };
  return { props: { param } };
}) satisfies GetStaticProps<{
  param: Param;
}>;

const Home = ({
  Component,
  pageProps,
  param,
}: AppProps & InferGetStaticPropsType<typeof getStaticProps>) => {
  const [date, setDate] = useState<string>(formatDateYyyymmdd(new Date()));
  const [selectedAreaNo, setSelectedAreaNo] = useState<string>('01');
  const [openMenu, setOpenMenu] = useState<boolean>(false);

  const selectedArea = param.areas.filter((a) => a.areaNo == selectedAreaNo)[0];

  useEffect(() => {
    const timerId = setInterval(() => {
      setDate((currentValue) => {
        const now = formatDateYyyymmdd(new Date());
        if (now !== currentValue) {
          return now;
        }

        return currentValue;
      });
    }, 5000);

    return () => clearInterval(timerId);
  });

  useEffect(() => {
    setSelectedAreaNo(localStorage.getItem('areaNo') ?? '01');
  }, []);

  const handleMenu = () => {
    setOpenMenu(true);
  };

  const handleClose = () => {
    setOpenMenu(false);
  };

  const handleChange = (e: React.ChangeEvent<HTMLSelectElement>): void => {
    setSelectedAreaNo(e.target.value);
    localStorage.setItem('areaNo', e.target.value);
  };

  return (
    <>
      <Head>
        <meta
          name="viewport"
          content="viewport-fit=cover, width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no"
        />
        <link rel="manifest" href="/manifest.json" />
        <link rel="apple-touch-icon" href="/icon.png"></link>
        <meta name="theme-color" content="#428cee" />
      </Head>
      <div
        className={`flex flex-col h-[100dvh] pb-iphone max-w-xl w-screen mx-auto box-border ${kosugiMaru.className}`}
      >
        <Header handleMenu={handleMenu} />
        <main className="flex flex-col h-full w-full text-zinc-700 bg-white text-xl">
          <MainHeader
            regions={param.regions}
            selectedAreaNo={selectedAreaNo}
            handleOnChange={handleChange}
            calendarUrl={selectedArea.calendarUrl}
          />
          <CardList today={date} area={selectedArea} />
        </main>
        <Footer />
        <Menu openMenu={openMenu} handleClose={handleClose} />
      </div>
    </>
  );
};

export default Home;
