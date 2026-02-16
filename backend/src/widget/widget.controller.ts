import { Controller, Get, Param, Logger } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiParam } from '@nestjs/swagger';
import { WidgetService } from './widget.service';
import { ApiResponseDto } from '../common/dto/api-response.dto';

@ApiTags('Widget')
@Controller('api/v1/widget')
export class WidgetController {
  private readonly logger = new Logger(WidgetController.name);

  constructor(private readonly widgetService: WidgetService) {}

  @Get('journey/:id')
  @ApiOperation({ summary: 'Get compact journey data for widget' })
  @ApiParam({ name: 'id' })
  async getJourneyWidget(@Param('id') id: string) {
    const data = await this.widgetService.getJourneyWidget(id);
    return new ApiResponseDto(data);
  }

  @Get('pnr/:pnrNumber')
  @ApiOperation({ summary: 'Get compact PNR data for widget' })
  @ApiParam({ name: 'pnrNumber', example: '4567891234' })
  async getPnrWidget(@Param('pnrNumber') pnrNumber: string) {
    const data = await this.widgetService.getPnrWidget(pnrNumber);
    return new ApiResponseDto(data);
  }
}
