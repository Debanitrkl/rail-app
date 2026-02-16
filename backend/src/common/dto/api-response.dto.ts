import { ApiProperty } from '@nestjs/swagger';

export class ApiResponseDto<T> {
  @ApiProperty()
  success: boolean;

  @ApiProperty()
  data: T;

  @ApiProperty({ required: false })
  message?: string;

  @ApiProperty({ required: false })
  timestamp: string;

  constructor(data: T, message?: string) {
    this.success = true;
    this.data = data;
    this.message = message;
    this.timestamp = new Date().toISOString();
  }
}

export class ApiErrorDto {
  @ApiProperty()
  success: boolean;

  @ApiProperty()
  error: string;

  @ApiProperty()
  statusCode: number;

  @ApiProperty()
  timestamp: string;

  constructor(error: string, statusCode: number) {
    this.success = false;
    this.error = error;
    this.statusCode = statusCode;
    this.timestamp = new Date().toISOString();
  }
}
