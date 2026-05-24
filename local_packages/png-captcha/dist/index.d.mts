import svgCaptcha from 'svg-captcha';

interface CaptchaResponse {
    text: string;
    width: number;
    height: number;
    image: Buffer;
}
declare const _default: {
    create: (args?: svgCaptcha.ConfigObject) => CaptchaResponse;
};

export { _default as default };
