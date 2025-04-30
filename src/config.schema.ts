import * as Joi from 'joi';

export const configSchemaValidation = Joi.object({
  APP_NAME: Joi.string().default('B3ERP API'),
  APP_PORT: Joi.number().default(3003),
  DB_HOST: Joi.string().default('localhost'),
  DB_PORT: Joi.number().default(3306),
  DB_USERNAME: Joi.string().required(),
  DB_PASSWORD: Joi.string().required(),
  DB_DATABASE: Joi.string().default('b3api'),
  JWT_SECRET: Joi.string().required(),
  AWS_REGION: Joi.string().default('sa-east-1'),
  AWS_SDK_KEY: Joi.string().required(),
  AWS_SDK_SECRET: Joi.string().required(),
  S3_BUCKET_NAME: Joi.string().default('b3erp-static'),
  SES_FROM_EMAIL: Joi.string().default('no-reply@b3erp.com.br'),
  UPLOAD_PATH: Joi.string()
    .optional()
    .default('/home/b3erp/web/b3rp.com.br/public_html/xstatic'),
  STATIC_URL: Joi.string().optional().default('https://xstatic.b3erp.com.br'),
  FRONTEND_URL: Joi.string().optional().default('https://app.b3erp.com.br'),
  BACKEND_URL: Joi.string().optional().default('https://api.b3erp.com.br'),
});
