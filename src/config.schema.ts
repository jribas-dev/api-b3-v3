import * as Joi from 'joi';

export const configSchemaValidation = Joi.object({
  APP_NAME: Joi.string().required(),
  APP_PORT: Joi.number().required(),
  DB_HOST: Joi.string(),
  DB_PORT: Joi.number(),
  DB_USERNAME: Joi.string().required(),
  DB_PASSWORD: Joi.string().required(),
  DB_DATABASE: Joi.string(),
  JWT_SECRET: Joi.string().required(),
  AWS_REGION: Joi.string(),
  AWS_SDK_KEY: Joi.string().required(),
  AWS_SDK_SECRET: Joi.string().required(),
  S3_BUCKET_NAME: Joi.string(),
  SES_FROM_EMAIL: Joi.string(),
  UPLOAD_PATH: Joi.string(),
  STATIC_URL: Joi.string(),
  FRONTEND_URL: Joi.string(),
  BACKEND_URL: Joi.string(),
});
