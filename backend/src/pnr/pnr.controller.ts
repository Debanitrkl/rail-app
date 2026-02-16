import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
  Body,
  Headers,
  Logger,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiParam, ApiHeader } from '@nestjs/swagger';
import { PnrService } from './pnr.service';
import { ApiResponseDto } from '../common/dto/api-response.dto';
import { WatchPnrDto } from './dto/pnr.dto';

@ApiTags('PNR')
@Controller('api/v1/pnr')
export class PnrController {
  private readonly logger = new Logger(PnrController.name);

  // Default user ID for development (in production, extract from JWT)
  private readonly defaultUserId = '00000000-0000-0000-0000-000000000001';

  private getUserId(authHeader?: string): string {
    // In production, decode JWT to get userId
    // For now, return a default user ID
    return this.defaultUserId;
  }

  constructor(private readonly pnrService: PnrService) {}

  @Get('watched')
  @ApiOperation({ summary: 'List all watched PNRs' })
  @ApiHeader({ name: 'Authorization', required: false })
  async getWatchedPnrs(@Headers('authorization') auth?: string) {
    const userId = this.getUserId(auth);
    const pnrs = await this.pnrService.getWatchedPnrs(userId);
    return new ApiResponseDto(pnrs);
  }

  @Get(':pnrNumber')
  @ApiOperation({ summary: 'Get PNR status' })
  @ApiParam({ name: 'pnrNumber', example: '4567891234' })
  async getPnrStatus(@Param('pnrNumber') pnrNumber: string) {
    const status = await this.pnrService.getPnrStatus(pnrNumber);
    return new ApiResponseDto(status);
  }

  @Post('watch')
  @ApiOperation({ summary: 'Add PNR to watchlist' })
  @ApiHeader({ name: 'Authorization', required: false })
  async watchPnr(
    @Body() dto: WatchPnrDto,
    @Headers('authorization') auth?: string,
  ) {
    const userId = this.getUserId(auth);
    const result = await this.pnrService.watchPnr(userId, dto);
    return new ApiResponseDto(result, 'PNR added to watchlist');
  }

  @Delete('watch/:pnrNumber')
  @ApiOperation({ summary: 'Remove PNR from watchlist' })
  @ApiParam({ name: 'pnrNumber', example: '4567891234' })
  @ApiHeader({ name: 'Authorization', required: false })
  async unwatchPnr(
    @Param('pnrNumber') pnrNumber: string,
    @Headers('authorization') auth?: string,
  ) {
    const userId = this.getUserId(auth);
    await this.pnrService.unwatchPnr(userId, pnrNumber);
    return new ApiResponseDto(null, 'PNR removed from watchlist');
  }
}
