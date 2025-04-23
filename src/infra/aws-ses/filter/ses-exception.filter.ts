// Adicione este exception filter
import { Catch, ExceptionFilter, ArgumentsHost } from '@nestjs/common';
import { SESv2ServiceException } from '@aws-sdk/client-sesv2';
import { Response } from 'express';

@Catch(SESv2ServiceException)
export class SesExceptionFilter implements ExceptionFilter {
  catch(exception: SESv2ServiceException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    const statusMap = {
      NotFoundException: 404,
      AlreadyExistsException: 409,
      ValidationException: 400,
    };

    const errcode = Object.prototype.hasOwnProperty.call(
      statusMap,
      exception.name,
    )
      ? statusMap[exception.name as keyof typeof statusMap]
      : 500;

    response.status(errcode).json({
      errorCode: exception.name,
      message: exception.message,
      awsRequestId: exception.$metadata.requestId,
    });
  }
}
