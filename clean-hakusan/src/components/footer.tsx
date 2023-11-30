import Image from 'next/image';

const Footer = () => {
  return (
    <footer className="flex justify-between items-center m-1">
      <small className="text-base">©2023 webarata3（ARATA Shinichi）</small>
      <a href="https://twitter.com/webarata3" target="_blank" className="w-4">
        <Image src="/image/twitter.svg" width={16} height={16} alt="" />
      </a>
    </footer>
  );
};

export default Footer;
